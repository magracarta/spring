<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-센터 > null > MBO등록
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-09-09 11:08:58
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        var auiGridSample;
        var sample = [];
        var mboName = [];
        var mboCd = [];
        var centers = [];
        
        $(document).ready(function () {
        	<c:forEach var="item" items="${mboTypeList}">
        		mboName.push("${item.code_name}");
        	</c:forEach>
        	<c:forEach var="item" items="${mboTypeList}">
        		mboCd.push("${item.code_value}");
	    	</c:forEach>
	    	<c:forEach var="item" items="${centers}">
            	centers.push("${item.example_field_name}");
        	</c:forEach>
	    	
	    	console.log(mboName);
	    	console.log(mboCd);
        	
            createAUIGrid();
            createAUIGridSample();
            
        });

        // 저장
        function goSave() {
        	if (AUIGrid.getGridData(auiGrid).length == 0) {
        		alert("등록할 데이터가 없습니다.");
        		return false;
        	}
        	
        	var editeRowItems = AUIGrid.getGridData(auiGrid); // 변경된 데이터
        	if (editeRowItems.length != mboCd.length) {
        		alert("MBO타입 개수가 안맞습니다.");
        		return false;
        	}
        	
            var list = [];

            for (var i = 0; i < editeRowItems.length; i++) {
                var keys = Object.keys(editeRowItems[i]); // 변경된 데이터 Key값 리스트
                var values = Object.values(editeRowItems[i]); // 변경된 데이터 value값 리스트
                for (var j = 0; j < keys.length; ++j) {
                	if (j == 0) {
                		continue;
                	}
                	var orgCode = keys[j].substring(2, 6);
                	if (orgCode == "uid") { // 왜그런지모르겠지만, uid가 들어감!
                		continue;
                	}
                	var mboAmt = values[j];
                	var param = {
                    	mbo_type_sb: mboCd[i].substring(0, 1),
                    	org_mbo_type_cd: mboCd[i],
                        org_code: orgCode,
                        mbo_amt: mboAmt,
                    }
                    list.push(param);
                }
            }
            
            console.log(list);
            
            if (centers.length * mboCd.length != list.length) {
            	alert("모든 센터가 지정되지 않았거나, MBO타입개수가 다릅니다.");
        		return false;
            }
            var objForm = $M.jsonArrayToForm(list);
            $M.setValue(objForm, "mbo_year", $M.getValue("mbo_year"));
            $M.setValue(objForm, "mbo_mon", $M.getValue("mbo_year") + $M.getValue("mbo_mon"));
            $M.goNextPageAjaxSave(this_page + "/save", objForm, {method: "POST"},
                function (result) {
                    if (result.success) {
                        alert("저장이 완료되었습니다.");
                        AUIGrid.setGridData(auiGrid, []);
                        // fnClose();
                    }
                }
            );
        }

        // 닫기
        function fnClose() {
            window.close();
        }
        
        // 양식 다운로드 (작년꺼 MBO 조회해서 다운로드)
        function fnDownloadExcel() {
        	var param = {
    			mbo_year : $M.toNum($M.getValue("mbo_year"))-1, 
    		}
   			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
   				function(result) {
   					if(result.success) {
   						if (result.list != null && result.list.length > 0) {
   							console.log(result.list);
   							AUIGrid.setGridData(auiGridSample, result.list);
   	   						fnExportExcel(auiGridSample, "MBO양식", {});
   						} else {
   							AUIGrid.setGridData(auiGridSample, sample);
   	   						fnExportExcel(auiGridSample, "MBO양식", {});
   						}
   					} else {
   						AUIGrid.setGridData(auiGridSample, sample);
	   					fnExportExcel(auiGridSample, "MBO양식", {});
   					}
   				}
   			); 
        }
        
        function createAUIGrid() {
            var gridPros = {
                editable: true, // 수정 모드
                selectionMode: "multipleCells", // 다중셀 선택
                showStateColumn: false,
            };

            var columnLayout = [
                {
                    headerText: "집계내역",
                    dataField: "org_mbo_type_name",
                    style: "aui-center",
                    width: "130",
                    minWidth: "50",
                    editable: false
                },
                <c:forEach var="item" items="${centers}">
                {
                    headerText: "${item.org_kor_name}",
                    dataField: "${item.field_name}",
                    style: "aui-center",
                    width: "100",
                    minWidth: "50",
                   	dataType: "numeric",
   					formatString: "#,##0",
                },
            	</c:forEach>
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);

            $("#auiGrid").resize();

            // cellEditEndBefore 이벤트 바인딩
            AUIGrid.bind(auiGrid, "cellEditEndBefore", function (event) {
                if (event.isClipboard) {
                    return event.value;
                }
                return event.value; // 원래값
            });

            AUIGrid.bind(auiGrid, "pasteEnd", function(event) {
                // 가장 위의 컬럼 이름은 복사 안되도록 수정
                var temp = AUIGrid.getGridData(auiGrid);
                temp.forEach((map,index) => {
                    if(!mboName.includes(map.org_mbo_type_name,0)) {
                        AUIGrid.removeRow(auiGrid, index);
                    }
                });
            });
        }
        
        function createAUIGridSample() {
        	var gridPros = {
        		showRowNumColumn: false,
        	};
        	var  orgList = [];
        	var columnLayout = [
                {
                    headerText: "집계내역",
                    dataField: "org_mbo_type_name",
                    style: "aui-center",
                    width: "130",
                    minWidth: "50"
                },
                <c:forEach var="item" items="${centers}">
                {
                    headerText: "${item.org_kor_name}",
                    dataField: "${item.example_field_name}",
                    style: "aui-center",
                    width: "100",
                    minWidth: "50",
                    dataType: "numeric",
					formatString: "#,##0",
                },
            	</c:forEach>
            ];
        	console.log(columnLayout);
        	auiGridSample = AUIGrid.create("#auiGridSample", columnLayout, gridPros);
        	console.log("${mboType}");
        	console.log(mboName);
        	for (var i = 0; i < mboName.length; ++i) {
       			var s = {
       				org_mbo_type_name : mboName[i],
       				<c:forEach var="item" items="${centers}">
       					"${item.example_field_name}" : 0,
       				</c:forEach>
       			}
       			sample.push(s);
        	}
            AUIGrid.setGridData(auiGridSample, sample);
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
            <!-- 검색조건 -->
            <div class="search-wrap mt5">
                <table class="table">
                    <colgroup>
                        <col width="60px">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th>등록년월</th>
                        <td>
                            <div class="form-row inline-pd">
                                <div class="col-auto">
                                    <jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
										<jsp:param name="sort_type" value="d"/>
										<jsp:param name="max_year" value="${inputParam.s_current_year+1}"/>
										<jsp:param name="year_name" value="mbo_year"/>
									</jsp:include>
                                </div>
                                <div class="col-auto">
                                    <select class="form-control" id="mbo_mon" name="mbo_mon">
                                        <c:forEach var="i" begin="1" end="12" step="1">
                                            <option value="<c:if test="${i < 10}">0</c:if><c:out value="${i}" />" <c:if test="${i==s_start_mon}">selected</c:if>>${i}월</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            </div>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <!-- /검색조건 -->
            <div class="title-wrap mt10">
            	<h4>MBO 업로드</h4>
                <div class="right">
	                    <div class="text-warning ml5">
							※ 엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여넣기(Ctrl+V) 하십시오, 양식 다운로드 시, 등록년도 -1년의 MBO데이터를 조회합니다.
							<button type="button" id="_fnDownloadExcel" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>양식다운로드</button>
	                    </div>
                </div>
            </div>
            <div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
            <div id="auiGridSample" style="height: 5px; visibility: hidden;"></div>

            <!-- 그리드 서머리, 컨트롤 영역 -->
            <div class="btn-group mt10">
                <div class="right">
                    <%-- <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include> --%>
                    <button type="button" class="btn btn-info" onclick="javascript:goSave();">저장</button>
                </div>
            </div>
            <!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>