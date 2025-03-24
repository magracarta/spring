<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 트러블슈팅 관리 > null > 점검사항 상세 등록
-- 작성자 : 황다은
-- 최초 작성일 : 2024-06-11 15:24:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        // 첨부할 수 있는 파일의 개수
        var fileCount = 5;

        // 연관이미지 파일 찾기
        function fnAddFile() {

            if($("input[name='img_file_seq']").size() >= fileCount) {
                alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
                return false;
            }

            openFileUploadPanel('fnPrintFile', 'upload_type=TROUBLE&file_type=img&total_max_count=5');
        }

        // 첨부파일 출력 (멀티)
        function fnPrintFile(file) {
            var str = '';
            str += '<div class="table-attfile-item att_file_' + file.file_seq + 'fileDiv"style="float:left; display:block;">';
            str += '<a href="javascript:fileDownload(' + file.file_seq + ');" style="color: blue; vertical-align: middle;">' + file.file_name + '</a>&nbsp;';
            str += '<input type="hidden" name="img_file_seq" value="' + file.file_seq + '"/>';
            str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(' + file.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
            str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
            str += '</div>';
            $('.att_file_div').append(str);
        }

        // 첨부파일 삭제
        function fnRemoveFile(fileSeq) {
            var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
            if (result) {
                var removeClassName = '.att_file_' + fileSeq + "fileDiv" ;
                $(removeClassName).remove();
            } else {
                return false;
            }
        }

        // 저장
        function goSave(){
            var frm = document.main_form;
            if($M.validation(frm) == false) {
                return false;
            }
            var addIdx = 1;
            $("input[name='img_file_seq']").each(function() {
                if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
                    $M.setValue('img_file_seq_' + addIdx, $(this).val());
                }
                addIdx++;
            });
            for(; addIdx <= fileCount; addIdx++) {
                $M.setValue('img_file_seq_' + addIdx, 0);
            }
            frm = $M.toValueForm(frm);

            $M.goNextPageAjaxSave(this_page + '/save', frm, {method : 'POST'},
                function(result) {
                    if(result.success) {
                        window.opener.fnAddTrouble($M.getValue("trouble_seq"));
                        fnClose();
                    }
                }
            );
        }

        // 닫기
        function fnClose() {
            window.close();
        }

    </script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
    <input type="hidden" id="trouble_seq" name="trouble_seq" value="${inputParam.trouble_seq}">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 폼테이블 -->
            <div>
                <div class="title-wrap">
                    <h4>점검상세</h4>
                </div>
                <div>
                    <table class="table-border">
                        <colgroup>
                            <col width="80px">
                            <col width="">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right essential-item">점검상세</th>
                            <td>
                                <input type="hidden" id="seq_no" name="seq_no" class="form-control" readonly value="0">
                                <textarea style="height: 110px; padding: 5px" id="check_text" name="check_text" alt="점검상세" required="required"></textarea>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">연관이미지</th>
                            <td>
                                <div class="table-attfile att_file_div">
                                    <div class="table-attfile">
                                        <button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
                                    </div>
                                </div>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <!-- /폼테이블-->
            <div class="btn-group mt10">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                </div>
            </div>
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>
