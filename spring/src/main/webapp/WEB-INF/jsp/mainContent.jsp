<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ include file="/WEB-INF/jsp/common/commonForAll.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<!DOCTYPE html> 
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGridTopLeft;
		var auiGridTopRight;
		
		$(document).ready(function() {
			
			// AUIGrid 생성 - 대리점이면 공지사항 X (신정애씨 QNA 요청 21.1.19)
			<c:if test="${SecureUser.org_type ne 'AGENCY'}">
				createauiGridTopLeft();
			</c:if>
			
			createauiGridTopRight();
		});
		
		function fnBarcodeRead(barcode) {
			fnBarcode(barcode, "Y");
		}

		// 바코드 팝업호출
		function fnBarcode(barcode, scanYn) {

			var barcdoeText;
			if(scanYn != "Y") {
				var msg = "전표바코드를 입력하세요.";
				barcdoeText = prompt("전표바코드를 입력하세요.");
				while (isNaN(barcdoeText) || barcdoeText.length != 12) {
					barcdoeText = prompt(msg);
				}
			} else {
				barcdoeText = barcode;
			}

			// part0203 -> search
			var param = {
				"s_doc_barcode_no" : barcdoeText
			};

			$M.goNextPageAjax("/part/part0203/barcode", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							goPopup(result);
						}
					}
			);
		}

		function goPopup(data) {
			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
			var params = {
				"doc_barcode_no" : data.bean.doc_barcode_no
			};

			switch (data.bean.doc_barcode_type_cd) {
				case "JOB_REPORT" :
					$M.goNextPage('/part/part0203p02', $M.toGetParam(params), {popupStatus: popupOption});
					break;
				case "PART_TRANS" :
					var loginOrgCode = data.login_org_code;
					if(data.beanPartTrans.from_warehouse_cd == loginOrgCode && data.beanPartTrans.to_warehouse_cd != loginOrgCode) {
						alert("부품출고처리 입니다.");
						$M.goNextPage('/part/part0203p01', $M.toGetParam(params), {popupStatus: popupOption});
					} else if(data.beanPartTrans.from_warehouse_cd != loginOrgCode && data.beanPartTrans.to_warehouse_cd == loginOrgCode) {
						alert("부품입고처리 입니다.");
						$M.goNextPage('/part/part0203p03', $M.toGetParam(params), {popupStatus: popupOption});
					} else {
						alert("처리자 창고가 맞지 않습니다.");
					}
					break;
				case "INOUT_DOC" :
					if(data.beanInoutDoc.part_sale_no == "") {
						$M.goNextPage('/part/part0203p03', $M.toGetParam(params), {popupStatus: popupOption});
					} else {
						$M.goNextPage('/part/part0203p01', $M.toGetParam(params), {popupStatus: popupOption});
					}
					break;
			}
		}
		
		function createauiGridTopLeft() {
			var gridPros = {
				showRowNumColumn : true,
				rowIdField : "_$uid",
			};
			
			var columnLayout = [
				{
					dataField : "notice_seq", 
					visible : false
				},
				{ 
					headerText : "구분", 
					dataField : "menu_name", 
					width : "100",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "필독",
					dataField : "must_read_yn",
					width : "40",
					editable : false,
				},
				{ 
					headerText : "제목", 
					dataField : "title", 
					style : "aui-left aui-popup",
					editable : false
				},
				{ 
					headerText : "첨부", 
					dataField : "file_yn", 
					width : "40",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "작성일", 
					dataField : "reg_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd", 
					width : "80",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "작성자", 
					dataField : "reg_mem_name", 
					width : "80",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "마감일", 
					dataField : "show_ed_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd", 
					width : "80",
					style : "aui-center",
				},
				{
					headerText : "조회수", 
					dataField : "read_cnt", 
					width : "50",
					style : "aui-center",
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridTopLeft = AUIGrid.create("#auiGridTopLeft", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridTopLeft, ${comList1});
			
			AUIGrid.bind(auiGridTopLeft, "cellClick", function(event) {
				if(event.dataField == "title") {
					var param = {
						"notice_seq" : event.item["notice_seq"],
					};
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=800, left=0, top=0";
					$M.goNextPage('/mmyy/mmyy0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
					AUIGrid.removeRow(auiGridTopLeft, "selectedIndex");
					AUIGrid.removeSoftRows(auiGridTopLeft);
					
					// notice_cnt_main_content
					var cnt = AUIGrid.getGridData(auiGridTopLeft).length;
					$("#notice_cnt_main_content").html(cnt);
				};
			});
		}
		
		function createauiGridTopRight() {
			var gridPros = {
				showRowNumColumn : true,
				rowIdField : "_$uid",
			};
			
			var columnLayout = [
				{
					dataField : "paper_seq", 
					visible : false
				},
				{ 
					headerText : "보낸이", 
					dataField : "send_mem_name", 
					width : "10%",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "쪽지내용", 
					dataField : "paper_contents", 
					style : "aui-left aui-popup",
					editable : false
				},
				{ 
					headerText : "수신일시", 
					dataField : "send_date",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss", 
					width : "20%",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "첨부파일", 
					dataField : "file_yn", 
					width : "8%",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "수신여부", 
					dataField : "send_gubun", 
					width : "8%",
					style : "aui-center",
				},
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridTopRight = AUIGrid.create("#auiGridTopRight", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridTopRight, ${comList2});
			
			AUIGrid.bind(auiGridTopRight, "cellClick", function(event) {
				if(event.dataField == "paper_contents") {
					var param = {
						"s_paper_seq" : event.item["paper_seq"],
						"s_paper_type" : 'RECEIVER'
					};
					var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=700, left=0, top=0";
					$M.goNextPage('/mmyy/mmyy0102p02', $M.toGetParam(param), {popupStatus : poppupOption});
					if (event.item.send_gubun != "미결") {
						AUIGrid.removeRow(auiGridTopRight, "selectedIndex");
						AUIGrid.removeSoftRows(auiGridTopRight);
					}
					// paper_cnt_main_content
					var cnt = AUIGrid.getGridData(auiGridTopRight).length;
					$("#paper_cnt_main_content").html(cnt);
				}
			});
		}
	    
	    // 공지사항
	    function goMain(title, url) {
	    	top.goContent(title, url);
	    }
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap mt5">
			<div class="content-box main-contents">
				<div class="main-title-todo">
					<h3>금일 할 일</h3>
					<div>
						<div class="box-type1">
							<div class="icon">
								<i class="material-iconsnotifications text-default"></i>
							</div>
							<div class="data">
								<span class="num" id="notice_cnt_main_content">${noticeCnt}</span>
								<span class="title">미 확인 공지</span>
							</div>
						</div>
						<div class="box-type1">
							<div class="icon">
								<i class="material-iconsemail text-default"></i>
							</div>
							<div class="data">
								<span class="num" id="paper_cnt_main_content">${paperCnt}</span>
								<span class="title">미 확인 및 미결 쪽지</span>
							</div>
						</div>
						<c:forEach items="${todoList}" var="item">
							<c:if test="${item.type eq 'type1'}">
								<div class="box-type1">
									<div class="icon">
										<i class="material-iconsdate_range text-default"></i>
									</div>
									<div class="data">
										<span class="num">${item.num}</span>
										<span class="title">${item.title}</span>
									</div>
								</div>
							</c:if>
							<c:if test="${item.type eq 'type2'}">
								<div class="box-type2">
									<div class="data">
										<span class="num">${item.num}</span>
										<span class="title">${item.title}</span>
										<!-- <span>※ 기준일시 : ${item.lastStandDateTime}</span> -->
									<div class="left" style="margin-left:50px;">
									</div>
									</div>
								</div>
								
							</c:if>
						</c:forEach>
					</div>
				</div>
				<div class="main-contents-wrap">
					<div class="contents">							
						<div class="row">
							<c:if test="${SecureUser.org_type ne 'AGENCY'}">
								<div class="col-6">
									<div class="title-wrap mt10">
										<h4>미 확인 공지사항</h4>
	<!-- 									<a href='javascript:void(0);' class='target' url='/comm/comm0116' title='정보수정'> -->
										<button type="button" class="btn btn-default" onclick="javascript:goMain('공지사항', '/mmyy/mmyy0101');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
	<!-- 									</a> -->
									</div>
									<div id="auiGridTopLeft" style="margin-top: 5px; height: 250px;"></div>
								</div>
							</c:if>
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>미 확인 및 미결 쪽지</h4>
									<button type="button" class="btn btn-default" onclick="javascript:goMain('쪽지함', '/mmyy/mmyy0102');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
								</div>
								<div id="auiGridTopRight" style="margin-top: 5px; height: 250px;"></div>
							</div>
						</div>
						<!-- 부서에 따라 그리드 다르게 표현 -->
 						<c:choose>
<%-- 							<c:when test="${showOrg eq 'MGT' }"><jsp:include page="/WEB-INF/jsp/mainContent_2000.jsp"/></c:when> --%>
<%-- 							<c:when test="${showOrg eq 'SALE' }"><jsp:include page="/WEB-INF/jsp/mainContent_4000.jsp"/></c:when> --%>
<%-- 							<c:when test="${showOrg eq 'SERV' }"><jsp:include page="/WEB-INF/jsp/mainContent_5000.jsp"/></c:when>--%>
<%-- 							<c:when test="${showOrg eq 'PART' }"><jsp:include page="/WEB-INF/jsp/mainContent_6000.jsp"/></c:when> --%>
							<c:when test="${showOrg eq 'CENTER' }"><jsp:include page="/WEB-INF/jsp/mainContent_center.jsp"/></c:when>
						</c:choose>
					</div>
				</div>
			</div>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>