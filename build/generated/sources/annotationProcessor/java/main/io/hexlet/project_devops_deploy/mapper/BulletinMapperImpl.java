package io.hexlet.project_devops_deploy.mapper;

import io.hexlet.project_devops_deploy.dto.BulletinDto;
import io.hexlet.project_devops_deploy.dto.BulletinRequest;
import io.hexlet.project_devops_deploy.model.Bulletin;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-09-11T10:54:43+0300",
    comments = "version: 1.6.3, compiler: IncrementalProcessingEnvironment from gradle-java-compiler-worker-9.7.0.jar, environment: Java 21.0.12 (Ubuntu)"
)
@Component
public class BulletinMapperImpl extends BulletinMapper {

    @Override
    public BulletinDto toDto(Bulletin entity) {
        if ( entity == null ) {
            return null;
        }

        BulletinDto.BulletinDtoBuilder bulletinDto = BulletinDto.builder();

        bulletinDto.id( entity.getId() );
        bulletinDto.title( entity.getTitle() );
        bulletinDto.description( entity.getDescription() );
        bulletinDto.state( entity.getState() );
        bulletinDto.contact( entity.getContact() );
        bulletinDto.price( entity.getPrice() );
        bulletinDto.imageKey( entity.getImageKey() );

        BulletinDto bulletinDtoResult = bulletinDto.build();

        fillImageUrl( entity, bulletinDtoResult );

        return bulletinDtoResult;
    }

    @Override
    public Bulletin toEntity(BulletinDto dto) {
        if ( dto == null ) {
            return null;
        }

        Bulletin bulletin = new Bulletin();

        bulletin.setId( dto.getId() );
        bulletin.setTitle( dto.getTitle() );
        bulletin.setDescription( dto.getDescription() );
        bulletin.setState( dto.getState() );
        bulletin.setContact( dto.getContact() );
        bulletin.setPrice( dto.getPrice() );
        bulletin.setImageKey( dto.getImageKey() );

        return bulletin;
    }

    @Override
    public Bulletin toEntity(BulletinRequest request) {
        if ( request == null ) {
            return null;
        }

        Bulletin bulletin = new Bulletin();

        bulletin.setTitle( request.getTitle() );
        bulletin.setDescription( request.getDescription() );
        bulletin.setState( request.getState() );
        bulletin.setContact( request.getContact() );
        bulletin.setPrice( request.getPrice() );
        bulletin.setImageKey( request.getImageKey() );

        return bulletin;
    }

    @Override
    public void updateEntity(BulletinRequest request, Bulletin bulletin) {
        if ( request == null ) {
            return;
        }

        if ( request.getTitle() != null ) {
            bulletin.setTitle( request.getTitle() );
        }
        if ( request.getDescription() != null ) {
            bulletin.setDescription( request.getDescription() );
        }
        if ( request.getState() != null ) {
            bulletin.setState( request.getState() );
        }
        if ( request.getContact() != null ) {
            bulletin.setContact( request.getContact() );
        }
        if ( request.getPrice() != null ) {
            bulletin.setPrice( request.getPrice() );
        }
        if ( request.getImageKey() != null ) {
            bulletin.setImageKey( request.getImageKey() );
        }
    }
}
