<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > Stock출하처리
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-06-24 13:17:16
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		<%-- 여기에 스크립트 넣어주세요. --%>
		var type = "";
		var auiGrid;
		
		$(document).ready(function() {
			createAUIGrid();
			type = "${inputParam.type}";
			if (type == "") {
				location.reload();
			}
		});
		
		function fnSetOrgCode(row) {
			/* console.log(row); */
			var param = {
				to_warehouse_name : row.org_name,
				to_warehouse_cd : row.org_code
			}
			$M.setValue(param);
			$("#display_org_name").html(row.org_name)
		}
		
		function goSave(mode) {
			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			}
			var frm = $M.toValueForm(document.main_form);
    		var concatCols = [];
    		var concatList = [];
    		var gridIds = [auiGrid];
    		for (var i = 0; i < gridIds.length; ++i) {
    			concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
    			concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
    		}
        	var gridForm = fnGridDataToForm(concatCols, concatList);

        	$M.copyForm(gridForm, frm);
			$M.goNextPageAjaxMsg("저장하시겠습니까?", this_page, gridForm, {method: 'post'},
                function (result) {
                    if (result.success) {
                        if(window.opener.location) {
                        	window.opener.location.reload();
                        	fnClose();
                        }
                    }
                }
            );
		}
		
		function fnClose() {
			window.close();
		}
		
		//그리드생성
		function createAUIGrid() {
			//그리드 생성 _ 지급품목
			var gridPros_product = {
				rowIdField : "_$uid",
				headerHeight : 20,
				rowHeight : 11, 
				footerHeight : 20,
				fillColumnSizeMode : false
			};
			var visibles = false;
			var columnLayout_product = [
				{
	        		dataField : "_$uid",
	        		visible : visibles
	        	},
	        	{
	        		dataField : "machine_doc_no",
	        		visible : visibles
	        	},
	        	{
	        		dataField : "part_no",
	        		headerText : "부품번호",
	        		style : "aui-center",
	        	},
	        	{
	        		dataField : "part_name",
	        		headerText : "부품명",
	        		style : "aui-left",
	        	},
	        	{
	        		dataField : "current_stock",
	        		headerText : "현재고",
	        		width : "10%"
	        	},
	        	{
	        		dataField : "qty",
	        		headerText : "수량",
	        		width : "10%"
	        	},
	        	{
	        		dataField : "no_out_qty",
	        		headerText : "미출고",
	        		width : "10%"
	        	},
	        	{
	        		dataField : "process_qty",
	        		headerText : "처리수량",
	        		width : "10%"
	        	},
	        	{
	        		dataField : "",
	        		headerText : "비고"
	        	}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout_product, gridPros_product);
			var partList = ${partList}
			$("#total_cnt").html(partList.length);
			AUIGrid.setGridData(auiGrid, partList);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if (event.item.current_stock != "") {
					if (event.dataField == "current_stock") {
						var param = {
							part_no : event.item.part_no
						}
						var popupOption1 = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1050, height=650, left=0, top=0";
						$M.goNextPage('/part/part0101p01', $M.toGetParam(param), {popupStatus : popupOption1});
					}
				}
			});
			$("#auiGrid").resize();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="machine_doc_no" value="${inputParam.machine_doc_no}">
<input type="hidden" name="type" value="${inputParam.type}">
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->						
            <table class="table-border mt5">
                <colgroup>
                    <col width="100px">
                    <col width="">
                    <col width="100px">
                    <col width="">
                </colgroup>
                <tbody>
                    <tr>
                        <th class="text-right">처리일자</th>
                        <td>
                            <div class="input-group width120px">
                                <input type="text" class="form-control border-right-0 calDate" value="${inputParam.s_current_dt}" dateFormat="yyyy-MM-dd" id="reg_dt" name="reg_dt">
                            </div>									
                        </td>
                        <th class="text-right">연계번호</th>
                        <td>
                            <input type="text" class="form-control width140px" value="${inputParam.machine_doc_no}" readonly="readonly">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">처리번호</th>
                        <td>
                            <input type="text" class="form-control width140px" readonly="readonly">			
                        </td>
                        <th class="text-right">요청일자</th>
                        <td>
                            <input type="text" class="form-control width120px" id="req_dt" name="req_dt" value="${stock.receive_plan_dt}" readonly="readonly" dateformat="yyyy-MM-dd">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">이동창고</th>
                        <td colspan="3">
                            <div class="form-row inline-pd widthfix">
                                <div class="col width80px">
                                    <input type="text" class="form-control" value="${stock.out_org_code}" id="from_warehouse_cd" name="from_warehouse_cd" readonly="readonly">
                                </div>
                                <div class="col width100px">
                                    <input type="text" class="form-control" value="${stock.out_org_name }" id="from_warehouse_name" name="from_warehouse_name" readonly="readonly">
                                </div>
                                <div class="col width33px" style="color: blue; font-weight: 600;">에서</div>
                                
                                	<c:choose>
                                		<c:when test="${inputParam.type eq 'recover'}">
                                			<div class="col width100px">
	                                			<div class="input-group">
			                                    	<input type="text" class="form-control border-right-0" readonly="readonly" value="${stock.display_org_code }" id="to_warehouse_cd" name="to_warehouse_cd" size="20" maxlength="20" style="background: white;">
			                                    	<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openOrgMapPanel('fnSetOrgCode');"><i class="material-iconssearch"></i></button>
			                                	</div>
		                                	</div>
                                		</c:when>
                                		<c:otherwise>
                                			<div class="col width80px">
                                				<input type="text" class="form-control" value="${stock.display_org_code }" id="to_warehouse_cd" name="to_warehouse_cd" readonly="readonly">
                                			</div>
                                		</c:otherwise>
                                	</c:choose>
                                
                                <div class="col width100px">
                                    <input type="text" class="form-control" value="${stock.display_org_name }" name="to_warehouse_name" name="to_warehouse_name" readonly="readonly" style="background: white;">
                                </div>
                                <div class="col width100px" style="margin-left: 10px; font-weight: 600;">
                                    	${SecureUser.kor_name }
                                </div>
                            </div>
                            <div>
                            	<c:if test="${inputParam.type eq 'recover'}"><div style="margin-top: 5px">STOCK출하장비 <span style="font-weight: 600;">${stock.machine_name }</span> (차대: ${stock.body_no } / 엔진: ${stock.engine_no_1 })도 <span style="display: inline-block;" id="display_org_name">${stock.display_org_name }</span> 보유장비로 이동합니다.</div></c:if>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
            <div id="auiGrid" style="margin-top: 5px; height: 250px;"></div>	
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
							<jsp:param name="pos" value="BOM_R"/>
					</jsp:include>
				</div>
			</div>
        </div>
    </div>	
</form>
</body>
</html>