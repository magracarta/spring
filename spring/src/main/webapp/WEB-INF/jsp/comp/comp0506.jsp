<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 장비연관팝업 > 장비연관팝업 > null > 수리내역조회
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-06-15 20:17:41
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        var fileIdx = 1; // 오픈한 파일 idx
        var fileSeq1;
        var fileSeq2;
        var fileSeq3;

        $(document).ready(function () {
            // AUIGrid 생성
            createAUIGrid();
            fnInit();

            goSearch();
        });


        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "row",
                showRowNumColumn: true,
            };

            var columnLayout = [
                {
                    headerText: "일지구분",
                    dataField: "as_type_name",
                    width: "6%",
                    style: "aui-center aui-popup",
                },
                {
                    headerText: "발행일자",
                    dataField: "as_dt",
                    dataType: "date",
                    formatString: "yyyy-mm-dd",
                    width: "7%",
                    style: "aui-center",
                    styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                        if (item.as_repair_type_ro.startsWith("RENT")) {
                            return " aui-popup"
                        }
                        return "aui-center";
                    }
                },
                {
                    headerText: "모델명",
                    dataField: "machine_name",
                    width: "7%",
                    style: "aui-center"
                },
                {
                    headerText: "모델일련번호",
                    dataField: "machine_seq",
                    visible: false
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    width: "7%",
                    style: "aui-center",
                },
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    width: "7%",
                    style: "aui-center",
                },
                {
                    headerText: "업체명",
                    dataField: "breg_name",
                    width: "7%",
                    style: "aui-center",
                },
                {
                    headerText: "연락처",
                    dataField: "hp_no",
                    width: "10%",
                    style: "aui-center",
                },
                {
                    headerText: "판매일자",
                    dataField: "sale_dt",
                    width: "7%",
                    dataType: "date",
                    formatString: "yyyy-mm-dd",
                    style: "aui-center",
                },
                {
                    headerText: "담당자",
                    dataField: "reg_mem_name",
                    width: "7%",
                    style: "aui-center",
                },
                {
                    headerText: "가동시간",
                    dataField: "op_hour",
                    width: "7%",
                    style: "aui-center",
                },
                {
                    headerText: "시작",
                    dataField: "custom_start_ti",
                    width: "7%",
                    style: "aui-center",
                },
                {
                    headerText: "종료",
                    dataField: "custom_end_ti",
                    width: "7%",
                    style: "aui-center",
                },
                {
                    headerText: "처리시간",
                    dataField: "repair_hour",
                    width: "7%",
                    style: "aui-center",
                },
                {
                    headerText: "처리센터",
                    dataField: "org_name",
                    width: "7%",
                    style: "aui-center",
                },
                {
                    headerText: "일지구분",
                    dataField: "as_repair_type_ro",
                    visible: false
                },
                {
                    headerText: "AS번호",
                    dataField: "as_no",
                    visible: false
                },
                {
                    headerText: "일지구분",
                    dataField: "as_repair_type_ro",
                    visible: false
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "as_type_name") {
                    var params = {
                        "s_as_no": event.item.as_no
                    }

                    if (event.item.as_repair_type_ro == "R") {
                        var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
                        $M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption});

                    } else if (event.item.as_repair_type_ro == "O") {

                        var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
                        $M.goNextPage('/serv/serv0102p12', $M.toGetParam(params), {popupStatus: popupOption});

                    } else if (event.item.as_repair_type_ro.startsWith("RENT")) {  // 렌탈회수/출고처리
                        params = {
                            "rental_doc_no" : event.item.as_no
                        };
                        popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
                        $M.goNextPage('/rent/rent0102p01', $M.toGetParam(params), {popupStatus : popupOption});

                    } else {
                        var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=700, height=450, left=0, top=0";
                        $M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
                    }
                }
                if (event.dataField == "as_dt") {
                    if (event.item.as_repair_type_ro.startsWith("RENT") ) {
                        if (event.item.auth_no == '') {
                            alert("고객에게 전송된 점검내역이 존재하지 않습니다.");
                        } else {
                            var params = {
                                "auth_no" : event.item.auth_no,
                                "show_yn" : "Y"
                            }
                            var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=700, height=450, left=0, top=0";
                            $M.goNextPage('/cust/rentalMachineDoc', $M.toGetParam(params), {popupStatus: popupOption});
                        }
                    }
                }
            });

        }

        function fnInit() {
            var file1 = "${checkImgList.job_file_seq_1}";
            if (file1 == "") {
                file1 = null;
            } else {
                fileSeq1 = file1;
                $("#image_area1").empty();
                $("#image_area1").append("<div class='attach-delete' style='display:none;' ><button type='button' class='btn btn-icon-lg text-light' onclick='javascript:fnRemoveFile(1)'><i class='material-iconsclose'></i></button></div><img id='asChkImage1' name='asChkImage1' src='/file/" + fileSeq1 + "' class='icon-profilephoto' tabindex=0 onclick='fnLayerImage("+ fileSeq1 +")' />");

            }
            var file2 = "${checkImgList.job_file_seq_2}";
            if (file2 == "") {
                file2 = null;
            } else {
                fileSeq2 = file2;
                $("#image_area2").empty();
                $("#image_area2").append("<div class='attach-delete' style='display:none;' ><button type='button' class='btn btn-icon-lg text-light' onclick='javascript:fnRemoveFile(2)'><i class='material-iconsclose'></i></button></div><img id='asChkImage2' name='asChkImage2' src='/file/" + fileSeq2 + "' class='icon-profilephoto' tabindex=0 onclick='fnLayerImage("+ fileSeq2 +")' />");
            }
            var file3 = "${checkImgList.job_file_seq_3}";
            if (file3 == "") {
                file3 = null;
            } else {
                fileSeq3 = file3;
                $("#image_area3").empty();
                $("#image_area3").append("<div class='attach-delete' style='display:none;' ><button type='button' class='btn btn-icon-lg text-light' onclick='javascript:fnRemoveFile(3)'><i class='material-iconsclose'></i></button></div><img id='asChkImage3' name='asChkImage3' src='/file/" + fileSeq3 + "' class='icon-profilephoto' tabindex=0 onclick='fnLayerImage("+ fileSeq3 +")' />");
            }

            //특정사용자만 파일업로드,삭제버튼 보이게 하기
            if ("${checkUploadYN}" == "Y") {
                $(".attach-delete").show();
                $(".attach-file").show();
            }
        }


        function goSearch() {
            if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
                return;
            }

            var param = {
                "s_start_dt": $M.getValue("s_start_dt"),
                "s_end_dt": $M.getValue("s_end_dt"),
                "s_as_type": $M.getValue("s_as_type"),
                "s_cust_no": $M.getValue("s_cust_no"),
                "s_body_no": $M.getValue("s_body_no"),
                "s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
                "s_sort_key": "as_dt ",
                "s_sort_method": "desc"
            };

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
                function (result) {
                    if (result.success) {
                        $("#total_cnt").html(result.total_cnt);
                        AUIGrid.setGridData(auiGrid, result.list);

                        var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
                        // 구해진 칼럼 사이즈를 적용 시킴.
                        AUIGrid.setColumnSizeList(auiGrid, colSizeList);
                    }
                }
            );
        }

        function setDeviceInfo(data) {
            $M.setValue("s_body_no", data.body_no);
            $M.setValue("s_cust_no", data.cust_no);
            $M.setValue("s_cust_name", data.cust_name);
            $M.setValue("s_machine_seq", data.machine_seq);
        }


        // 파일찾기 팝업
        function goSearchFile(idx) {
            fileIdx = idx;
            var param = {
                max_width: 768,
                max_height: 1024,
                upload_type: 'SERVICE',
                file_type: 'img',
                max_size: 300
            };
            openFileUploadPanel("fnSetImage", $M.toGetParam(param));
        }

        // 팝업창에서 받아온 값
        function fnSetImage(result) {
            if (result != null && result.file_seq != null) {

                var fileSeq = result.file_seq;

                $M.goNextPageAjax(this_page + "/save" + "/" + fileIdx + "/" + result.file_seq, "", {method: "POST"},
                    function (result) {
                        if (result.success) {
                            if (fileIdx == 1) {
                                fileSeq1 = fileSeq;
                            } else if (fileIdx == 2) {
                                fileSeq2 = fileSeq;
                            } else {
                                fileSeq3 = fileSeq;
                            }

                            // 이미지 그려주기 작업
                            $("#image_area" + fileIdx).empty();
                            $("#image_area" + fileIdx).append(
                                "<div class='attach-delete' ><button type='button' class='btn btn-icon-md text-light' onclick='javascript:fnRemoveFile(" + fileIdx + ")'><i class='material-iconsclose'></i></button></div>"
                                + "<img id='chkImage' name='chkImage' src='/file/" + fileSeq + "' class='icon-profilephoto' tabindex=0 onclick='fnLayerImage("+ fileSeq +")' />");

                        } else {
                            alert(result);
                        }
                    }
                );
            }
        }


        // 기간별 점검표 이미지 삭제
        function fnRemoveFile(idx) {
			if(confirm("삭제 하시겠습니까?") == false) {
				return false;
			}
        	
            $M.goNextPageAjax(this_page + "/remove/" + idx, "", {method: "POST"},
                function (result) {
                    if (result.success) {
                        if (idx == 1) {
                            fileSeq1 = null;
                        } else if (idx == 2) {
                            fileSeq2 = null;
                        } else {
                            fileSeq3 = null;
                        }

                        $("#image_area" + idx).empty();
                        $("#image_area" + idx).append("<div class='no-img'><i class='icon-noimg'></i><div class='no-img-txt'>no images</div></div>");
                    } else {
                        alert(result);
                    }
                }
            );
        }


        // 닫기
        function fnClose() {
            window.close();
        }

        function fnDownloadExcel() {
            var exportProps = {
                // 제외항목
            };
            fnExportExcel(auiGrid, "수리내역조회", exportProps);
        }

        // 전화상담일지 등록
        function goNew() {
            var params = {
                "s_machine_seq" : $M.getValue("s_machine_seq")
            };

            var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=820, left=0, top=0";
            $M.goNextPage('/serv/serv0102p13', $M.toGetParam(params), {popupStatus: popupOption});
		}
        
        function fnLayerImage(fileSeq) {
//         	$M.goNextPageLayerImage("${inputParam.ctrl_host}" + "/file/svc/" + fileSeq);
			var params = {
					file_seq : fileSeq
			};
			
			var popupOption = "";
			$M.goNextPage('/comp/comp0709', $M.toGetParam(params), {popupStatus : popupOption});
        }
    </script>
</head>

<body class="bg-white">
<form id="main_form" name="main_form">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="row widthfix">
                <!-- 좌측 폼테이블-->
                <div class="col width200px">
                    <div class="title-wrap">
                        <h4>장비 유지보수 기간차트</h4>
                    </div>
                    <div class="checklist-item">
                        <div class="attach-file" style="display:none;">
<!--                         <div class="attach-file"> -->
                            <button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchFile(1)">파일찾기</button>
                        </div>
                        <div class="no-img" id="image_area1">
                            <i class="icon-noimg"></i>
                            <div class="no-img-txt">no images</div>
                        </div>
                    </div>
                    <div class="checklist-item">
                        <div class="attach-file" style="display:none;">
<!--                         <div class="attach-file"> -->
                            <button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchFile(2)">파일찾기</button>
                        </div>
                        <div class="no-img" id="image_area2">
                            <i class="icon-noimg"></i>
                            <div class="no-img-txt">no images</div>
                        </div>
                    </div>
                    <div class="checklist-item">
                        <div class="attach-file" style="display:none;">
<!--                         <div class="attach-file"> -->
                            <button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchFile(3)">파일찾기</button>
                        </div>

                        <div class="no-img" id="image_area3">
                            <i class="icon-noimg"></i>
                            <div class="no-img-txt">no images</div>
                        </div>

                    </div>
                </div>
                <!-- /좌측 폼테이블-->
                <!-- 우측 폼테이블-->
                <div class="col" style="width: calc(100% - 200px)">
                    <div class="title-wrap">
                        <h4>수리내역조회</h4>
                    </div>
                    <!-- 검색영역 -->
                    <div class="search-wrap mt5">
                        <table class="table">
                            <colgroup>
                                <col width="65px">
                                <col width="270px">
                                <col width="50px">
                                <col width="100px">
                                <col width="60px">
                                <col width="120px">
                                <col width="60px">
                                <col width="120px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>발행일자</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-5">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="" value="${inputParam.s_start_dt}">
                                            </div>
                                        </div>
                                        <div class="col-auto">~</div>
                                        <div class="col-5">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="${inputParam.s_end_dt}">
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <th>일지구분</th>
                                <td>
                                    <select class="form-control" id="s_as_type" name="s_as_type" class="form-control">
                                        <option value="">- 전체 -</option>
                                        <option value="REPAIR">서비스</option>
                                        <option value="CALL">전화상담</option>
                                        <option value="RENT_O">출고점검사항</option>
                                        <option value="RENT_R">회수점검사항</option>
                                    </select>
                                </td>
                                <th>차대번호</th>
                                <td>
                                    <div class="input-group">
                                        <input type="hidden" id="s_machine_seq" name="s_machine_seq" value="${map.machine_seq}">
                                        <input type="text" class="form-control border-right-0" id="s_body_no" name="s_body_no" class="s_body_no" value="${map.body_no}" readonly="readonly">
                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchDeviceHisPanel('setDeviceInfo');"><i class="material-iconssearch"></i></button>
                                    </div>
                                </td>
                                <th>차주명</th>
                                <td>
                                    <div class="input-group">
                                        <c:choose>
                                            <c:when test="${empty inputParam.s_cust_no}">
                                                <input type="hidden" id="s_cust_no" name="s_cust_no" value="">
                                                <input type="text" class="form-control border-right-0" id="s_cust_name" name="s_cust_name" class="s_cust_name" value="" readonly="readonly">
                                            </c:when>
                                            <c:otherwise>
                                                <input type="hidden" id="s_cust_no" name="s_cust_no" value="${ map.cust_no}">
                                                <input type="text" class="form-control border-right-0" id="s_cust_name" name="s_cust_name" class="s_cust_name" value="${ map.cust_name}" readonly="readonly">
                                            </c:otherwise>
                                        </c:choose>
                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchDeviceHisPanel('setDeviceInfo');"><i class="material-iconssearch"></i></button>
                                    </div>
                                </td>
                                <td class="">
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <!-- 조회결과 -->
                    <div class="title-wrap mt10">
                        <h4>조회결과</h4>
                        <div class="btn-group">
                            <div class="right">
                                <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
                                        <label class="form-check-input" for="s_masking_yn">마스킹 적용</label>
                                    </div>
                                </c:if>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <div id="auiGrid" style="margin-top: 5px; height: 700px;"></div>
                    <!-- /조회결과 -->
                    <div class="btn-group mt10">
                        <div class="left">
                            총 <strong class="text-primary" id="total_cnt">0</strong>건
                        </div>
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                        </div>
                    </div>
                </div>
                <!-- /우측 폼테이블-->
            </div>
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>